--坠杀
local s,id=GetID()

function s.initial_effect(c)
	--规则上当作「铁鳞」卡
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x1F7A)
	c:RegisterEffect(e0)

	--① 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost_release)
	e1:SetTarget(s.tg_summon)
	e1:SetOperation(s.op_summon)
	c:RegisterEffect(e1)

	--② 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.cost_release)
	e2:SetTarget(s.tg_set)
	e2:SetOperation(s.op_set)
	c:RegisterEffect(e2)
end

-- 可解放的水族怪兽（双方场上）
function s.filter_release(c)
	return c:IsRace(RACE_AQUA) and c:IsReleasableByEffect()
end

-- cost：解放双方场上的1只水族怪兽
function s.cost_release(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter_release,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.filter_release,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Release(g,REASON_COST)
end

-- 可特殊召唤的水族怪兽（自己墓地·除外）
function s.filter_sp(c,e,tp)
	return c:IsRace(RACE_AQUA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--① target（★ 删掉了位置检测，避免满场时无法发动）
function s.tg_summon(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.IsExistingMatchingCard(s.filter_sp,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

--① operation
function s.op_summon(e,tp,eg,ep,ev,re,r,rp)
	-- 选场上最多2张卡送去墓地
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end

	-- 从自己墓地·除外特召1只水族怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter_sp),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #sg==0 then return end
	local tc=sg:GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc:IsType(TYPE_NORMAL) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

--② target
function s.tg_set(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and e:GetHandler():IsSSetable()
	end
	Duel.SetOperationInfo(0,CATEGORY_SSET,e:GetHandler(),1,0,0)
end

--② operation
function s.op_set(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SSet(tp,c)==0 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
end

return s
