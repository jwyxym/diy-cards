--极端情绪
function c21362827.initial_effect(c)
	aux.AddCodeList(c,21362830)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,21362827)
	e1:SetTarget(c21362827.actg)
	e1:SetOperation(c21362827.acop)
	c:RegisterEffect(e1) 
	--Activate
	--local e1=Effect.CreateEffect(c)
	--e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	--e1:SetType(EFFECT_TYPE_ACTIVATE)
	--e1:SetCode(EVENT_FREE_CHAIN) 
	---e1:SetCountLimit(1,21362827)
	--e1:SetTarget(c21362827.target)
	--e1:SetOperation(c21362827.activate)
	--c:RegisterEffect(e1) 
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21362828)
	e2:SetCondition(c21362827.thcon)
	e2:SetTarget(c21362827.thtg)
	e2:SetOperation(c21362827.thop)
	c:RegisterEffect(e2)
	--teh
	--local e2=Effect.CreateEffect(c)
	--e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	--e2:SetType(EFFECT_TYPE_IGNITION)   
	--e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	--e2:SetRange(LOCATION_GRAVE)  
	--e2:SetCountLimit(1,21362828)
	--e2:SetTarget(c21362827.tehtg)
	--e2:SetOperation(c21362827.tehop)
	--c:RegisterEffect(e2)
end
function c21362827.filter(c,e,tp)
	return true 
end 
function c21362827.mfilter(c,e,tp)
	return true 
end 
function c21362827.rcheck(tp,g,c)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end
function c21362827.rgcheck(g,ec)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=1
end
function c21362827.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp) 
		local mg2=nil 
		aux.RCheckAdditional=c21362827.rcheck
		aux.RGCheckAdditional=c21362827.rgcheck 
		local res=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c21362827.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
		aux.RCheckAdditional=nil
		aux.RGCheckAdditional=nil
		return res 
	end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE) 
end
function c21362827.acop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg=Duel.GetRitualMaterial(tp) 
	local mg2=nil 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.RCheckAdditional=c21362827.rcheck
	aux.RGCheckAdditional=c21362827.rgcheck
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c21362827.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if mg2 then
			mg:Merge(mg2)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then
			aux.RCheckAdditional=nil
			aux.RGCheckAdditional=nil
			goto cancel
		end 
		tc:SetMaterial(mat)
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		if dmat:GetCount()>0 then
			mat:Sub(dmat)
			Duel.SendtoGrave(dmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)  
		if tc:IsCode(21362830) then 
			local e1=Effect.CreateEffect(rc)
			e1:SetDescription(aux.Stringid(21362827,0))
			e1:SetCategory(CATEGORY_DRAW)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCondition(c21362827.drcon)
			e1:SetTarget(c21362827.drtg)
			e1:SetOperation(c21362827.drop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true) 
		end 
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	end
end
function c21362827.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function c21362827.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c21362827.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c21362827.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp) 
		local mg2=nil
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,21362800) then 
			--mg2=Duel.GetMatchingGroup(aux.RitualExtraFilter,tp,LOCATION_EXTRA,0,nil,c21362827.mfilter)  
			mg2=Duel.GetMatchingGroup(aux.RitualExtraFilter,tp,LOCATION_GRAVE,0,nil,c21362827.mfilter)
		end 
		aux.RCheckAdditional=c21362827.rcheck
		aux.RGCheckAdditional=c21362827.rgcheck 
		local res=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c21362827.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
		aux.RCheckAdditional=nil
		aux.RGCheckAdditional=nil
		return res 
	end
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,21362800) then 
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
		e:SetLabel(1)  
	else 
		e:SetLabel(0)
	end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE) 
end
function c21362827.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg=Duel.GetRitualMaterial(tp) 
	local mg2=nil
	if e:GetLabel()==1 then 
		--mg2=Duel.GetMatchingGroup(aux.RitualExtraFilter,tp,LOCATION_EXTRA,0,nil,c21362827.mfilter)  
		mg2=Duel.GetMatchingGroup(aux.RitualExtraFilter,tp,LOCATION_GRAVE,0,nil,c21362827.mfilter) 
	end 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.RCheckAdditional=c21362827.rcheck
	aux.RGCheckAdditional=c21362827.rgcheck
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c21362827.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if mg2 then
			mg:Merge(mg2)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then
			aux.RCheckAdditional=nil
			aux.RGCheckAdditional=nil
			goto cancel
		end 
		tc:SetMaterial(mat)
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		if dmat:GetCount()>0 then
			mat:Sub(dmat)
			Duel.SendtoGrave(dmat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function c21362827.thckfil(c,tp) 
	return c:IsControler(tp) and c:IsRace(RACE_FIEND) 
end 
function c21362827.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21362827.thckfil,1,nil,tp)
end 
function c21362827.thtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c21362827.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SendtoHand(c,nil,REASON_EFFECT) 
	end 
end 



function c21362827.tefil(c) 
	return c:IsAbleToDeck() and c:IsFaceup() and c:IsSetCard(0xba38) 
end 
function c21362827.tehtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) 
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c21362827.tefil(chkc) end   
	if chk==0 then return Duel.IsExistingTarget(c21362827.tefil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) and e:GetHandler():IsAbleToHand() end 
	local g=Duel.SelectTarget(tp,c21362827.tefil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0) 
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end 
function c21362827.tehop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler() 
	local tc=Duel.GetFirstTarget() 
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then 
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end 
end 






