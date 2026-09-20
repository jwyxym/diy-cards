--妖精種 コットンボール
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
-- ②：把手卡·场上的这张卡解放才能发动。从自己的卡组·墓地把有「古代妖精龙」的卡名记述的1张魔法·陷阱卡在自己场上盖放。
-- ③：自己主要阶段才能发动。这张卡的等级上升最多有自己场上的怪兽数量的数值。
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,25862681)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把手卡·场上的这张卡解放才能发动。从自己的卡组·墓地把有「古代妖精龙」的卡名记述的1张魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。这张卡的等级上升最多有自己场上的怪兽数量的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*200)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
-- ①
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		Duel.SpecialSummonComplete()
	end
end
-- ②
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,25862681) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
-- ③
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) and ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local lv=Duel.AnnounceLevel(tp,1,ct)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(lv)
		c:RegisterEffect(e1)
	end
end
