-- 转阶魔法·三生散尽
local s,id,o=GetID()
function s.initial_effect(c)
	-- 这张卡在规则上也当作「渊狱」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xd84)
	c:RegisterEffect(e0)

	-- ①：特召水族超量并叠放素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：墓地回收
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- 连锁响应限制：自己场上表侧表示怪兽只有 1 只的场合
function s.chlimit(e,ep,tp)
	return tp==ep
end

-- ①效果过滤：目标水族超量怪兽
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end

-- ①效果过滤：额外卡组特召的目标超量怪兽
function s.filter2(c,e,tp,mc)
	local rk=mc:GetRank()
	return c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
		and c:IsAttribute(mc:GetAttribute()) and c:IsRank(rk)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,rk)
end

-- 墓地/除外区被重叠的怪兽过滤
function s.matfilter(c,rk)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER)
		and (c:IsLevel(rk) or c:IsRank(rk))
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and not c:IsForbidden()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	if Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==1 then
		Duel.SetChainLimit(s.chlimit)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
			-- 把场上的这张卡叠为素材
			if c:IsRelateToEffect(e) then
				c:CancelToGrave()
				Duel.Overlay(sc,c)
			end
			-- 把墓地·除外状态的 1 只符合条件的怪兽叠为素材
			local rk=sc:GetRank()
			local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,rk)
			if #sg>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local mat=sg:Select(tp,1,1,nil)
				Duel.Overlay(sc,mat)
			end
		end
	end
end

-- ②效果处理
function s.costfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	g:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end