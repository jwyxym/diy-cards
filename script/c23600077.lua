-- 天蚀降诞 (ID: 23600077)
local s,id,o=GetID()
local SET_ECLIPSE=0xd92 -- 「天蚀」字段代码

function s.initial_effect(c)
	-- ①：这张卡也能把自己场上1只昆虫族超量怪兽解放来发动。
	-- 以自己场上1只昆虫族超量怪兽为对象才能发动。把1只昆虫族·光属性超量怪兽在作为对象的自己的超量怪兽上面重叠当作超量召唤从额外卡组特殊召唤,并把这张卡在下面重叠作为超量素材。
	-- 把怪兽解放来把这张卡发动的场合，对方不能对应这个效果的发动把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：超量素材的这张卡被取除而送去墓地的结束阶段才能发动。墓地的这张卡在自己场上盖放。
	-- 监听取除送墓事件
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop2)
	c:RegisterEffect(e2)

	-- 结束阶段在场上盖放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id) -- 这个卡名的②的效果1回合只能使用1次
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果相关判定 ====================
function s.xyzfilter(c,e,tp,mc)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end

function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end

function s.cfilter(c,e,tp)
	-- 若选择解放怪兽发动，场上必须存在另外1只合法的对象怪兽
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ) and c:IsReleasable()
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,c,e,tp)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 解放判定：本回合未曾解放怪兽发动过 且 场上有合法的昆虫族超量怪兽（1回合只能解放1次）
	local can_trib=Duel.GetFlagEffect(tp,id+o*100)==0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 本回合尚未使用过解放发动，询问是否解放1只怪兽发动
	if can_trib and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		Duel.Release(g,REASON_COST)
		-- 注册本回合已解放标记（1回合只能解放1次）
		Duel.RegisterFlagEffect(tp,id+o*100,RESET_PHASE+PHASE_END,0,1)
		e:SetLabel(1)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)

	-- 把怪兽解放来发动的场合，封锁对方对应此效果发动的连锁
	if e:GetLabel()==1 then
		Duel.SetChainLimit(s.chainlm)
	end
end

function s.chainlm(e,rp,tp)
	return tp==rp
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		-- 将原超量怪兽的原素材与自身一同继承垫入
		local mg=tc:GetOverlayGroup()
		if #mg~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
			-- 并把这张卡在下面重叠作为超量素材
			if c:IsRelateToEffect(e) then
				c:CancelToGrave()
				Duel.Overlay(sc,c)
			end
		end
	end
end

-- ==================== ② 效果：取除送墓后结束阶段盖放 ====================
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定：必须曾作为超量素材且送去墓地
	if c:IsPreviousLocation(LOCATION_OVERLAY) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end