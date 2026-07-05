--时空大盗拉法姆
local s,id=GetID()

function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.wincon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.wintg)
	e2:SetOperation(s.winop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_REMOVED,0,c)
	if chk==0 then
		return g:CheckSubGroup(aux.dncheck,9,9) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:SelectSubGroup(tp,aux.dncheck,true,9,9)
			if sg and sg:GetCount()==9 then
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
end
function s.regfilter(c)
	return c:IsSetCard(0xcf0) and not c:IsLevel(10) and c:IsType(TYPE_MONSTER)
end
function s.gfilter(c)
	return c:IsSetCard(0xcf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        local code=tc:GetOriginalCodeRule()-44990000
        if s.regfilter(tc) and Duel.GetFlagEffect(tp,id+code)==0 then
            Duel.RegisterFlagEffect(tp,id+code,0,0,0)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(tc:GetOriginalCodeRule(),2))
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetTargetRange(1,0)
            Duel.RegisterEffect(e1,tp)
        end
    end
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	local count = 0
	for code=0,100 do
		if Duel.GetFlagEffect(tp,id+code)~=0 then
			count = count + 1
			if count >= 9 then
				return true
			end
		end
	end
	return false
end

function s.wintg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.regfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_REMOVED,0,c)
		return g:CheckSubGroup(aux.dncheck,9,9)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,9,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_WIN,0,0,0,0)
end

function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,REASON_EFFECT)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler()==e:GetOwner() and re:GetHandlerPlayer()==tp then
		Duel.SetChainLimit(s.chainlimit)
	end
end
function s.chainlimit(e,rp,tp)
	return tp==rp
end
function s.chainfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler()==e:GetOwner()
end
