--温泉娘·润目亚莉亚
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e0=aux.AddLinkProcedure(c,s.mfilter,2)
	e0:SetProperty(e0:GetProperty()|EFFECT_FLAG_SET_AVAILABLE)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(s.atklimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tglimit)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetCondition(s.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id)
	e6:SetCost(s.cost)
	e6:SetTarget(s.postg)
	e6:SetOperation(s.posop)
	c:RegisterEffect(e6)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.poscon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
function s.mfilter(c)
	return c:IsLinkSetCard(0xd89) and (c:IsFaceupEx() or c:IsLinkRace(RACE_AQUA))
end
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) and not (c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP))
end
function s.atklimit(e,c)
	return c~=e:GetHandler()
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
function s.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*200
end
function s.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.band(ec:GetLinkedZone(c:GetPreviousControler()),bit.lshift(0x1,c:GetPreviousSequence()))~=0
	end
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e:GetHandler())
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP)
end
function s.posfilter2(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #mg>0 end
	e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,0,nil)
	if mg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sg1=mg:Select(tp,1,mg:GetCount(),nil)
		if sg1:GetCount()>0 then
			Duel.HintSelection(sg1)
			local ct=Duel.ChangePosition(sg1,POS_FACEDOWN_DEFENSE)
			local mg2=Duel.GetMatchingGroup(s.posfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			if mg2:GetCount()>0 and ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
				local sg2=mg2:Select(tp,1,ct,nil)
				if sg2:GetCount()>0 then
					Duel.HintSelection(sg2)
					Duel.ChangePosition(sg2,POS_FACEDOWN_DEFENSE)
				end
			end
		end
	end
end