--传达的乐音:R·I·O·T
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id+id)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
end
function s.linkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf09) and c:GetMutualLinkedGroupCount()>0
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
	return #g>=4
end

function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:CancelToGrave()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_REMAIN_FIELD)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTargetRange(0,1)
		e2:SetTarget(s.splimit)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_SKIP_M2)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTargetRange(0,1)
		c:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e4:SetRange(LOCATION_SZONE)
		e4:SetTarget(s.rmtarget)
		e4:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
		e4:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e4)
		local e5=e3:Clone()
		e5:SetCode(EFFECT_SKIP_DP)
		c:RegisterEffect(e5)
	end
end
function s.rmtarget(e,c)
	return c:GetOwner()==1-e:GetHandlerPlayer() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.link1filter(c)
	return c:IsFaceup() and c:IsLink(1) and c:IsSetCard(0xf09)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	local g=Duel.GetMatchingGroup(s.link1filter,tp,LOCATION_MZONE,0,nil)
	local mg,atk=g:GetMinGroup(Card.GetAttack)
	if atk>0 then
		return c:GetAttack()<atk
	end
end
function s.tgfilter(c)
	return c:IsSetCard(0xf09) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
