--NEWGAME! 篠田初
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,0))
    e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,m)
	e4:SetCondition(cm.thcon)
	e4:SetTarget(cm.thtg)
	e4:SetOperation(cm.thop)
	c:RegisterEffect(e4)
	--todeck
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,m+1)
	e5:SetTarget(cm.tdtg)
	e5:SetOperation(cm.tdop)
	c:RegisterEffect(e5)
    -- if not cm.global_check then
	-- 	cm.global_check=true
    --     local ge0=Effect.CreateEffect(c)
	-- 	ge0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- 	ge0:SetCode(EVENT_CUSTOM+10700563)
	-- 	ge0:SetOperation(cm.adop)
	-- 	Duel.RegisterEffect(ge0,0)
	-- 	local ge1=Effect.CreateEffect(c)
	-- 	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	-- 	ge1:SetCode(EVENT_ADJUST)
	-- 	ge1:SetOperation(cm.checkop)
	-- 	ge1:SetLabelObject(ge0)
	-- 	Duel.RegisterEffect(ge1,0)
	-- end
end

-- function cm.adop(e,tp,eg,ep,ev,re,r,rp)
-- 	if Duel.GetFlagEffect(tp,m)==0 then
-- 		Duel.RegisterFlagEffect(tp,m+1,0,0,1)
-- 	end
-- 	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
-- 	g:KeepAlive()
-- 	e:SetLabelObject(g)
-- end

-- function cm.opcfilter(c)
-- 	return c:IsFaceup() and c:IsLocation(0x40) and c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousPosition(POS_FACEUP)
-- end

-- function cm.checkop(e,tp,eg,ep,ev,re,r,rp)
-- 	if Duel.GetFlagEffect(tp,m)==0 then
-- 		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+10700563,e,0,0,0,0)
-- 	end
-- 	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
-- 	local pg=e:GetLabelObject():GetLabelObject()
-- 	if #g==0 and not pg then return false end
-- 	if #g~=0 and not pg then
-- 		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+10700563,e,0,0,0,0)
-- 	end
-- 	if (#g==0 and #pg~=0) or (not g:Equal(pg)) then
-- 		if pg then
-- 			local ng=pg:Filter(cm.opcfilter,nil)
-- 			if #ng>0 then
-- 				Duel.RaiseSingleEvent(ng,EVENT_CUSTOM+10700564,e,0,0,0,0)
-- 			end
-- 		end
-- 		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+10700563,e,0,0,0,0)
-- 	end
-- end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_PENDULUM) and g:GetClassCount(Card.GetCode)==#g
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.contfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(0x40) and not (c:IsExtraDeckMonster() and c:IsControler(tp))
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.contfilter,1,nil,tp)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=eg:Filter(cm.contfilter,nil,tp)
    if chk==0 then return cg:IsExists(Card.IsAbleToDeck,1,nil) end
    Duel.SetTargetCard(cg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,cg,math.min(#cg,2),nil,nil)
end

function cm.optfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAbleToDeck()
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(cm.optfilter,nil,e)
    if #tg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=tg:Select(tp,1,2,nil)
        Duel.SendtoDeck(g,tp,2,REASON_EFFECT)
    end
end

function cm.tgtfilter(c)
    return c:IsAbleToDeck() and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(cm.tgtfilter,tp,0x40,0x40,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,nil,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,0x40)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,cm.tgtfilter,tp,0x40,0x40,1,2,nil)
		if #g>0 then
			g:AddCard(c)
        	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		end
    end
end