-- 转阶天卫-阿特洛波斯 (ID: 23600006)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 超量召唤手续：光属性6星怪兽×2只以上
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),6,2,nil,nil,99)
	c:EnableReviveLimit()

	-- ①：这张卡的种族也当作这张卡作为超量素材中的怪兽的各自种族使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.raceval)
	c:RegisterEffect(e1)

	-- ②：自己·对方回合，取除1个超量素材，把1只和这张卡相同种族的光属性6阶超量怪兽重叠超量召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o*100) -- HOPT 防冲突限制码
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- ③：持有这张卡作为素材中的6阶超量怪兽得到以下效果（作为超量素材时获得：EFFECT_TYPE_XMATERIAL）
	-- ● 攻击力·守备力上升场上的怪兽数量×600
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(s.rk6con)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)

	-- ● 对方不能对应这张卡的效果的发动把效果发动
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_XMATERIAL)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCondition(s.rk6con)
	e6:SetOperation(s.chainop)
	-- 利用触发链使持卡怪兽获得连锁封锁
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_CHAINING)
	e7:SetCondition(s.chaincon)
	e7:SetOperation(s.chainop)
	c:RegisterEffect(e7)
end

-- ==================== ① 效果：素材种族附加 ====================
function s.raceval(e,c)
	local g=e:GetHandler():GetOverlayGroup()
	local race=0
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_MONSTER) then
			race=race|tc:GetOriginalRace()
		end
	end
	return race
end

-- ==================== ② 效果：二速重叠超量召唤 ====================
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.spfilter(c,e,tp,mc,race)
	return c:IsType(TYPE_XYZ) and c:IsRank(6) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsRace(race)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local race=c:GetRace()
		return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,race)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local race=c:GetRace()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,race)
	local tc=g:GetFirst()
	if tc then
		local mg=c:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(tc,mg)
		end
		tc:SetMaterial(Group.FromCards(c))
		Duel.Overlay(tc,Group.FromCards(c))
		Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

-- ==================== ③ 效果：素材赋予 ====================
function s.rk6con(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsRank(6)
end

function s.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_MZONE,LOCATION_MZONE)*600
end

function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return s.rk6con(e) and re:GetHandler()==c
end

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(s.chainlimit)
end

function s.chainlimit(e,rp,tp)
	return tp==rp
end