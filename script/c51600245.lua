--灾厄造物 克苏鲁之眼
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,51600245)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)

	--atk limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.indescon)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_FUSION and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.filter(c)
	return (c:IsSetCard(0x911) and c:IsAbleToGrave())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,2,nil) and Duel.GetFlagEffect(tp,id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_EXTRA)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,EFFECT_FLAG_OATH,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x911) and c:IsLocation(LOCATION_EXTRA)
end



function s.indesfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x518)
end
function s.indescon(e)
	return Duel.IsExistingMatchingCard(s.indesfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
