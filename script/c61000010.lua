--火取凭依 霞烈仙
local s,id,o=GetID()
function s.initial_effect(c)
	--超量召唤。正规手续为不死族8星怪兽×2；也可把手卡的不死族怪兽全部丢弃，在自己场上的不死族超量怪兽上面重叠来超量召唤
	aux.AddXyzProcedure(c,s.mfilter,8,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--自己对「火取凭依 霞烈仙」1回合只能有1次特殊召唤
	c:SetSPSummonOnce(id)
	--①：这张卡特殊召唤的场合才能发动。选自己的场上·墓地·除外状态最多2张卡在这张卡下面重叠作为超量素材。那之后，可以再选场上最多2张魔法·陷阱卡回到卡组
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--②：1回合1次，把这张卡的超量素材全部取除才能发动。这张卡的攻击力上升对方墓地·除外状态的卡的数量×300的数值。那之后，选自己·对方墓地的1只不死族怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--③：这张卡不会成为对方的效果的对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--③：这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetValue(2)
	c:RegisterEffect(e4)
end
--正规超量素材：不死族怪兽（等级由AddXyzProcedure的8指定）
function s.mfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
--替代手续的叠放对象：自己场上表侧表示的不死族超量怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_XYZ)
end
--替代手续的代价：手卡的不死族怪兽
function s.hdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and c:IsDiscardable()
end
--把手卡的不死族怪兽全部丢弃
function s.xyzop(e,tp,chk)
	local ct=Duel.GetMatchingGroupCount(s.hdfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return ct>0 end
	Duel.DiscardHand(tp,s.hdfilter,ct,ct,REASON_COST+REASON_DISCARD,nil)
end
--①：可以在这张卡下面重叠作为超量素材的自己的卡（场上的卡需要表侧表示）
function s.mtfilter(c,tc)
	return c:IsCanOverlay() and c~=tc and (not c:IsLocation(LOCATION_ONFIELD) or c:IsFaceup())
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
	if Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	end
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg=g:Select(tp,1,math.min(g:GetCount(),2),nil)
		if sg:GetCount()>0 then
			Duel.HintSelection(sg)
			Duel.Overlay(c,sg)
		end
	end
	--那之后，可以再选场上最多2张魔法·陷阱卡回到卡组
	local tg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if tg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local rg=tg:Select(tp,1,math.min(tg:GetCount(),2),nil)
		if rg:GetCount()>0 then
			Duel.HintSelection(rg)
			Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
--①：场上最多2张魔法·陷阱卡
function s.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
--②：把这张卡的超量素材全部取除
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:GetOverlayCount()
	c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
--②：自己·对方墓地的不死族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE+LOCATION_REMOVED)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ct*300)
		c:RegisterEffect(e1)
	end
	Duel.BreakEffect()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
